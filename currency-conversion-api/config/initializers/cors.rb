Rails.application.config.middleware.insert_before 0, Rack::Cors do
  if Rails.env.development?
    allow do
      origins "http://localhost:5173"
      resource "*", headers: :any, methods: [ :get, :post, :options ]
    end
  else
    allowed = ENV.fetch("CORS_ORIGINS", "").split(",").map(&:strip)
    allow do
      origins(*allowed)
      resource "*", headers: :any, methods: [ :get, :post, :options ]
    end
  end
end
