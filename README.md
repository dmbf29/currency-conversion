# Currency Conversion App

A full-stack currency conversion application, featuring a Rails API backend and React frontend with live exchange rate caching.

🌐 **Live Demo**: [Currency Converter](https://dmbf29.github.io/currency-conversion-react/)

## Project Overview
- **Real-time currency conversion** using live exchange rates
- **Rate caching** (1-hour cache per currency pair)
- **Conversion history tracking** with persistent storage
- **Modern React UI** with responsive design
- **Comprehensive test coverage** with RSpec

## Architecture

### Backend (Rails API)
- **Framework**: Ruby on Rails (API-only mode)
- **Database**: PostgreSQL
- **External API**: [Frankfurter API](https://frankfurter.dev) for exchange rates
- **Deployment**: Heroku

### Backend Features
- [☑️] Converts amounts between currencies using live exchange rates from Frankfurter API.
- [☑️] Caches exchange rates per currency pair in the database for 1 hour to reduce external API calls.
- [☑️] Stores each conversion record in the database.
- [☑️] Exposes a `POST /convert` endpoint to perform conversions.
- [☑️] Exposes a `GET /conversions` endpoint to fetch recent conversion history.
- [☑️] Includes validations on models (ExchangeRate, Conversion) to ensure data integrity.
- [☑️] RSpec tests covering model validations and core logic.

### Frontend (React SPA)
- **Framework**: React
- **Styling**: Tailwind CSS
- **API Integration**: Fetch API for backend communication
- **Deployment**: Github Pages

### Frontend Features
- [☑️] User interface for amount and currency input
- [☑️] Backend API integration for conversions
- [☑️] Display converted amount, exchange rate, and timestamp
- [☑️] Recent conversions list from backend

## API Endpoints

### POST /api/v1/conversions
Convert an amount from one currency to another.

**Request:**
```json
{
  "from_currency": "USD",
  "to_currency": "EUR",
  "amount": 100
}
```

**Response:**
```json
{
  "id": 1,
  "from_currency": "USD",
  "to_currency": "EUR",
  "amount": 100.0,
  "converted_amount": 85.23,
  "exchange_rate": 0.8523,
  "rate_timestamp": "2024-08-08T10:30:00Z",
  "created_at": "2024-08-08T10:35:00Z"
}
```

### GET /api/v1/conversions
Retrieve recent conversion history.

**Response:**
```json
{
  "conversions": [
    {
      "id": 1,
      "from_currency": "USD",
      "to_currency": "EUR",
      "amount": 100.0,
      "converted_amount": 85.23,
      "exchange_rate": 0.8523,
      "rate_timestamp": "2024-08-08T10:30:00Z",
      "created_at": "2024-08-08T10:35:00Z"
    }
  ]
}
```

## Getting Started


### Backend Setup
```bash
cd currency-conversion-api
bundle install
rails db:create db:migrate db:seed
rails server
```

The API will be available at `http://localhost:3000`

### Frontend Setup
```bash
cd currency-conversion-react
npm install
npm run dev
```

The React app will be available at `http://localhost:5173`

### Running Tests
```bash
cd currency-conversion-api
bundle exec rspec
```

## Caching Strategy
1. **Cache Check**: Before making external API calls, check if a valid cached rate exists
2. **Cache Miss**: If no cache or expired (>1 hour), fetch fresh rates from Frankfurter API
3. **Cache Hit**: Use cached rate for immediate response
4. **Cache Update**: Store new rates with timestamp for future use

This approach minimizes external API calls while ensuring rate accuracy.


## Future Possibly Enhancements
- Add `/currencies` endpoint for the API
- User authentication and personal conversion history
- Additional currency providers for redundancy
- Currency rate charts and analytics
