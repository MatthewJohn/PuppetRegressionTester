Puppet Regression Tester
=======================

## Installation

* Install the required packages:

```apt-get install vagrant libtext-template-perl libfile-touch-perl perl-tk```

* Create the local directories

```mkdir logs vagrant```

## Install vagrant images


## Logging

There are several different types of logging, here they are:

| Logging Type  | Log Prepend   | Description |
| ------------- |:-------------:| -----:|
| Debug   | DEBUG:   | I am doing this under the cover. |
| Normal  |          | Here is my status - it has probably changed. |
| Warning | WARNING: | This didn't go as planned - thought you might wanna know! |
| Error   | FATAL:   | Holy Shit! That wasn't meant to happen... Don't think we can continue, Jim! |
