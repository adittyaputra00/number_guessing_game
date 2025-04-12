#!/bin/bash

# PSQL variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask for username
echo "Enter your username:"
read username

# Check if the user exists in the database
user_check=$($PSQL "SELECT username FROM users WHERE username = '$username';")

if [[ -z $user_check ]]; then
  # New user
  echo "Welcome, $username! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$username');"
else
  # Existing user
  user_data=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$username';")
  games_played=$(echo $user_data | awk '{print $1}')
  best_game=$(echo $user_data | awk '{print $2}')
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

# Generate random number between 1 and 1000
secret_number=$((RANDOM % 1000 + 1))
guess_count=0

# Ask the user to guess the number
echo "Guess the secret number between 1 and 1000:"

while true; do
  read guess

  # Check if input is an integer
  if [[ ! $guess =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  guess_count=$((guess_count + 1))

  # Check the guess
  if [[ $guess -lt $secret_number ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $guess -gt $secret_number ]]; then
    echo "It's lower than that, guess again:"
  else
    # Correct guess
    echo "You guessed it in $guess_count tries. The secret number was $secret_number. Nice job!"

    # Update games played and best game if necessary
    if [[ $games_played -eq 0 || $guess_count -lt $best_game || $best_game -eq 0 ]]; then
      $PSQL "UPDATE users SET games_played = games_played + 1, best_game = $guess_count WHERE username = '$username';"
    else
      $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$username';"
    fi
    break
  fi
done

