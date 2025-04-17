#!/bin/bash

# PSQL variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read USERNAME

# Check if the user exists
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME';")

if [[ -z $USER_DATA ]]; then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME');"
  GAMES_PLAYED=0
  BEST_GAME=0
else
  # Returning user
  GAMES_PLAYED=$(echo $USER_DATA | cut -d'|' -f1)
  BEST_GAME=$(echo $USER_DATA | cut -d'|' -f2)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate the secret number
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# Initialize guess counter
NUMBER_OF_GUESSES=1

# Prompt for guess
echo "Guess the secret number between 1 and 1000:"

while read GUESS; do
  # Validate input
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Compare guess with secret number
  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
    ((NUMBER_OF_GUESSES++))
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
    ((NUMBER_OF_GUESSES++))
  else
    # Correct guess
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    
    # Update database
    if [[ $BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
      $PSQL "UPDATE users SET games_played = games_played + 1, best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME';"
    else
      $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';"
    fi
    break
  fi
done
