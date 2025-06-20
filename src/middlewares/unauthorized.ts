import { NextFunction, Request, Response } from "express";

export const authGuard = (request: Request, response: Response, next: NextFunction) => {
  // @ts-ignore
  if (request.session && request.session.username) {
    next()
  } else {
    response.redirect('/login')
  }
}