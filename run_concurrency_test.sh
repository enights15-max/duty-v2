#!/bin/bash

# Configuration
USER_ID=$1
DEBIT_AMOUNT=$2
CONCURRENCY=$3

if [ -z "$USER_ID" ] || [ -z "$DEBIT_AMOUNT" ] || [ -z "$CONCURRENCY" ]; then
    echo "Usage: ./run_concurrency_test.sh <user_id> <amount> <concurrency_level>"
    exit 1
fi

echo "Spawning $CONCURRENCY processes for User $USER_ID, debiting $DEBIT_AMOUNT each..."

for i in $(seq 1 $CONCURRENCY); do
    # Run in background
    php artisan wallet:test-concurrency $USER_ID $DEBIT_AMOUNT --idempotency_key="stress_test_$i" &
done

wait
echo "All processes finished. Check the logs for results."
