import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  clearMocks: true,
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageProvider: 'v8',
  collectCoverageFrom: ['src/**/*.{ts,tsx}', '!<rootDir>/node_modules/'],
  testMatch: ['**/tests/unit/**/*.test.ts'],

  modulePathIgnorePatterns: [
    'src/domain/Builders/',
    'src/domain/exceptions/',
    'src/domain/model/',
    'src/domain/ports/',
    'src/libraries',
    'src/entrypoints/schemas',
  ],

  moduleNameMapper: {
    '^@app/(.*)$': '<rootDir>/src/app/$1',
    '^@config/(.*)$': '<rootDir>/src/config/$1',
    '^@handler/(.*)$': '<rootDir>/src/handler/$1',
    '^@libraries/(.*)$': '<rootDir>/src/libraries/$1',
    '^@middlewares/(.*)$': '<rootDir>/src/middlewares/$1',
    '^@models/(.*)$': '<rootDir>/src/models/$1',
    '^@services/(.*)$': '<rootDir>/src/services/$1',
  },
};

export default config;
