import { NextFunction, Request, Response } from "express";

export const errorHandler = (error: any, _request: Request, response: Response, _next: NextFunction) => {
  console.log(error)

  response.status(500).json({
    code: error.code || 'UNCONTROLLER_ERROR',
    message: error.message || 'An unexpected error has occurred. 😥'
  })
}