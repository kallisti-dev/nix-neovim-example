#!/usr/bin/env bash
# Fixture for the match-and-surround scenario.
# Lines 4-6: if/fi, which % matches only with matchit or matchup.
if true; then
  echo "hello"
fi

# Line 10 provides nested brackets for matching; line 5 supplies surround text.
# Keep these line numbers stable: the behavior scenario addresses them directly.
value=$(printf '%s' "world")
