#!/bin/bash

inxi -Fx | awk '/cpu/' | awk -F : '{print $4}' | awk '{print $1}'
