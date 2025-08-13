import express, { Express } from 'express'
import { notFound } from '@middlewares/not-found'
import { errorHandler } from '@middlewares/error-handler'
import { userRouter } from '@handler/user.routes'
import { Constants } from '@config/contants'

const serverConfig = (app: Express): Express => {
  app.set('PORT', Constants.PORT || 3000)

  app.use(express.json())
  app.use(express.urlencoded({ extended: true }))
  app.use(express.static('public'))

  app.get('/', (_request, response) => {
    response.status(200).json({
      code: 'SUCCESS',
      message: 'Welcome to API v1. 👋'
    })
  })

  app.use('/api/v1/users', userRouter)
  app.use(errorHandler)
  app.use(notFound)

  return app
}

export { serverConfig }