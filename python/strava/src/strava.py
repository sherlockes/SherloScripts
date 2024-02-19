from stravalib.client import Client
from dotenv import load_dotenv
import os

load_dotenv()

# Variables para las llaves de Strava
client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')

client = Client()
MY_STRAVA_CLIENT_ID, MY_STRAVA_CLIENT_SECRET = open('client.secret').read().strip().split(',')
print ('Client ID and secret read from file'.format(MY_STRAVA_CLIENT_ID) )