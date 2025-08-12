import { NextFunction, Request, Response } from "express";
import LambdaLogger from '@libraries/logger';

export const errorHandler = (error: any, _request: Request, response: Response, _next: NextFunction) => {
  const err = error as Error
  LambdaLogger.error({
    code: 'ERROR_GET_ALL_USERS',
    message: 'Error getting all users',
    metadata: { error: err.message }
  })

  response.status(500).json({
    code: error.code || 'UNCONTROLLER_ERROR',
    message: error.message || 'An unexpected error has occurred. 😥'
  })
}