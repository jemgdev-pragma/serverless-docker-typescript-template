require('dotenv').config()
import 'reflect-metadata'
import express from 'express'
import { serverConfig } from './server-config'
import { AppDataSource } from './data-source'

AppDataSource.getInstance().initialize().then(() => {
  console.log('Database is connected successfuly')
}).catch((error) => console.log(error))

const app = express()
const server = serverConfig(app)

server.listen(server.get('PORT'), () => {
  console.log(`Love reminder running on port ${server.get('PORT')}`)
})