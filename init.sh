#!/bin/bash

APP_DIR=/home/ruby/yamon-grid
ENV=development
PORT=3008

function _start
{
	echo start ...
	thin start -e $ENV -p $PORT -d
}

function _stop
{
	echo stop ...
	thin stop
}

cd $APP_DIR

case $1 in
	start)
		_start
		;;
	stop)
		_stop
		;;
	restart)
		_stop
		_start
esac
