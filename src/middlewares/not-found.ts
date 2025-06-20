import { Request, Response } from "express";

const notFound = (_request: Request, response: Response) => {
  response.status(404).json({
    code: 'NOT_FOUND',
    message: 'Reource not found'
  })
}

export { notFound }