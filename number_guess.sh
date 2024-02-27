#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(( 1 + RANDOM % 1000 ))
TRIES=0
GUESSED=false

# prompt for username
echo Enter your username:
read USERNAME

ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# if not found
if [[ -z $ID ]]
then
  # insert user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")

  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # get user stats
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"

while [[ $GUESSED = false ]]
do
  read INPUT

  # check if input is an integer
  if [[ $INPUT =~ ^[0-9]+$ ]]
  then
    # increment tries
    (( TRIES++ ))

    # if correct
    if [[ $INPUT -eq $NUMBER ]]
    then
      GUESSED=true
      echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"

      # update user row
      UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")

      if [[ -z $BEST_GAME || $TRIES -lt $BEST_GAME ]]
      then
        UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $TRIES WHERE username = '$USERNAME'")
      fi
    # if greater than
    elif [[ $INPUT -gt $NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
    # if less than
    elif [[ $INPUT -lt $NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
    fi
  else
    echo -e "\nThat is not an integer, guess again:"
  fi
done