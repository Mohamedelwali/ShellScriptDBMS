#!/bin/bash

DB_DIR="./databases"

# Ensure databases directory exists
mkdir -p "$DB_DIR"

main_menu() {
    while true; do
        echo "====== DBMS Main Menu ======"
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect To Database"
        echo "4. Drop Database"
        echo "5. Exit"
        read -p "Select an option [1-5]: " choice

        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option. Try again." ;;
        esac
    done
}

create_database() {
    read -p "Enter new database name: " dbname
    if [ -z "$dbname" ]; then
        echo "Database name cannot be empty."
    elif [ -d "$DB_DIR/$dbname" ]; then
        echo "Database already exists."
    else
        mkdir "$DB_DIR/$dbname"
        echo "Database '$dbname' created."
    fi
}

list_databases() {
    echo "Databases:"
    ls "$DB_DIR"
}

connect_database() {
    read -p "Enter database name to connect: " dbname
    if [ -d "$DB_DIR/$dbname" ]; then
        echo "Connected to '$dbname'."
        # Call the database menu here
        database_menu "$dbname"
    else
        echo "Database does not ex


main_menu
