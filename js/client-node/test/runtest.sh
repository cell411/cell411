#!/bin/bash

exec > >(tee $1.out)
exec 2>&1
exec "$@"
