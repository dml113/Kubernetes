# 고랭으로 만든 DocumentDB & ElastiCache 데이터베이스 저장용 Application
## app.go
```
package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"github.com/go-redis/redis/v8"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var (
	ctx    = context.Background()
	client *mongo.Client
	rdb    *redis.Client
)

type Song struct {
	Title  string `json:"title"`
	Singer string `json:"singer"`
	Text   string `json:"text"`
}

type Secrets struct {
	MongoUri  string `json:"mongoUri"`
	RedisAddr string `json:"redisAddr"`
}

func main() {
	secrets := getSecrets("/secrets/skills/app")
	var err error
	client, err = mongo.Connect(ctx, options.Client().ApplyURI(secrets.MongoUri))
	if err != nil {
		log.Fatal(err)
	}
	defer client.Disconnect(ctx)
	rdb = redis.NewClient(&redis.Options{
		Addr: secrets.RedisAddr,
	})

	fs := http.FileServer(http.Dir("./static"))
	http.Handle("/", fs)
	http.HandleFunc("/cd", handleSongs)
	http.HandleFunc("/health", healthCheckHandler)

	log.Fatal(http.ListenAndServe(":8080", nil))
}

func getSecrets(secretName string) Secrets {
	awsRegion := "ap-northeast-2"
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(awsRegion),
	})
	if err != nil {
		log.Fatal(err)
	}
	svc := secretsmanager.New(sess)
	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secretName),
	}
	result, err := svc.GetSecretValue(input)
	if err != nil {
		log.Fatal(err)
	}
	var secrets Secrets
	json.Unmarshal([]byte(*result.SecretString), &secrets)

	return secrets
}

func handleSongs(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "POST":
		saveSong(w, r)
	case "GET":
		searchSong(w, r)
	default:
		http.Error(w, "Unsupported method", http.StatusMethodNotAllowed)
	}
}

func saveSong(w http.ResponseWriter, r *http.Request) {
	var song Song
	if err := json.NewDecoder(r.Body).Decode(&song); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	collection := client.Database("cd").Collection("songs")
	_, err := collection.InsertOne(ctx, song)
	if err != nil {
		http.Error(w, "Error saving to MongoDB", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func searchSong(w http.ResponseWriter, r *http.Request) {
	title := strings.TrimPrefix(r.URL.Path, "/cd/")
	cachedSong, err := rdb.Get(ctx, title).Result()
	if err == nil {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(cachedSong))
		return
	}
	collection := client.Database("cd").Collection("songs")
	var song Song
	err = collection.FindOne(ctx, bson.M{"title": title}).Decode(&song)
	if err != nil {
		http.Error(w, "Song not found", http.StatusNotFound)
		return
	}
	songJSON, _ := json.Marshal(song)
	rdb.Set(ctx, title, songJSON, 0)
	w.Header().Set("Content-Type", "application/json")
	w.Write(songJSON)
}

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	response := map[string]int{"status code": 200}
	json.NewEncoder(w).Encode(response)
}

```
## index.html
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Song Manager</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .container { width: 80%; margin: auto; }
        .form-group { margin-bottom: 15px; }
        label { display: block; }
        input[type="text"], textarea { width: 100%; padding: 8px; }
        button { padding: 10px 15px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background-color: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Song Manager</h1>
        <div>
            <h2>Save Song</h2>
            <div class="form-group">
                <label for="title">Title:</label>
                <input type="text" id="title">
            </div>
            <div class="form-group">
                <label for="singer">Singer:</label>
                <input type="text" id="singer">
            </div>
            <div class="form-group">
                <label for="text">Text:</label>
                <textarea id="text"></textarea>
            </div>
            <button onclick="saveSong()">Save Song</button>
        </div>

        <div>
            <h2>Search Song</h2>
            <div class="form-group">
                <label for="searchTitle">Title:</label>
                <input type="text" id="searchTitle">
            </div>
            <button onclick="searchSong()">Search Song</button>
            <div id="searchResult"></div>
        </div>
    </div>

    <script>
        function saveSong() {
            var title = document.getElementById('title').value;
            var singer = document.getElementById('singer').value;
            var text = document.getElementById('text').value;

            fetch('/cd', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ title: title, singer: singer, text: text }),
            })
            .then(response => response.text())
            .then(data => {
                alert('Song Saved');
                document.getElementById('title').value = '';
                document.getElementById('singer').value = '';
                document.getElementById('text').value = '';
            })
            .catch((error) => {
                console.error('Error:', error);
            });
        }

        function searchSong() {
            var title = document.getElementById('searchTitle').value;

            fetch('/cd/' + title)
            .then(response => response.json())
            .then(data => {
                var result = `Title: ${data.title}<br>Singer: ${data.singer}<br>Text: ${data.text}`;
                document.getElementById('searchResult').innerHTML = result;
            })
            .catch((error) => {
                console.error('Error:', error);
                document.getElementById('searchResult').innerHTML = 'Song not found';
            });
        }
    </script>
</body>
</html>
```
## needed package
```
go get github.com/aws/aws-sdk-go/aws
go get github.com/aws/aws-sdk-go/aws/session
go get github.com/aws/aws-sdk-go/service/secretsmanager
go get github.com/go-redis/redis/v8
go get go.mongodb.org/mongo-driver/mongo
```
