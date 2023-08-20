#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES=$($PSQL "SELECT * FROM services")

MAIN_MENU() {
    echo "$SERVICES" | while read SERVICE_ID BAR NAME; do
        echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED

    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/ //')

    # check if service exists
    if [[ -z $SERVICE_NAME ]]; then
        MAIN_MENU "I could not find that service. What would you like today?"
    else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE phone = '$CUSTOMER_PHONE'" | sed 's/ //')

        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]; then
            echo -e "\nWhat's your name?"
            read CUSTOMER_NAME

            # insert new customer
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) 
            VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        fi

        # get customer id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # get service time
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME

        # insert appointment
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time)
        VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
}

MAIN_MENU