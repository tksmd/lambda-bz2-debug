#!/usr/bin/env python
# -*- coding: utf-8 -*-

from logging import getLogger, INFO, basicConfig

import os
import ctypes

for d, dirs, files in os.walk('lib'):
    for f in files:
        if f.endswith('.a'):
            continue
        ctypes.cdll.LoadLibrary(os.path.join(d, f))

import bz2

basicConfig()
logger = getLogger(__name__)
logger.setLevel(INFO)

def lambda_handler(event, context):
    logger.info('Hello world')
    logger.info(event)

    return "debug"


if __name__ == '__main__':
    lambda_handler({'resource': '/debug', 'httpMethod': 'POST'}, None)
