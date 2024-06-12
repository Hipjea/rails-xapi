Rails.application.routes.draw do
  mount XapiMiddleware::Engine => "/xapi_middleware"
end
