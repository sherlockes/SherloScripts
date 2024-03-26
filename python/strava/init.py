from stravalib import Client
client = Client()

url = client.authorization_url(client_id=MY_STRAVA_CLIENT_ID,                              redirect_uri='http://127.0.0.1:5000/authorization')
