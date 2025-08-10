class Api::V1::ConversionsController < ApplicationController
  before_action :validate_required_params, only: [ :create ]

  def create
    conversion_data = ConversionService.convert(
      amount: conversion_params[:amount],
      from: conversion_params[:from],
      to: conversion_params[:to]
    )

    if conversion_data[:error]
      render json: { errors: [ conversion_data[:message] ] }, status: :unprocessable_content
    else
      @conversion = Conversion.new(conversion_data)
      if @conversion.save
        render :create, status: :created
      else
        render json: { errors: @conversion.errors.full_messages }, status: :unprocessable_content
      end
    end
  end

  def index
    @conversions = Conversion.order(created_at: :desc).limit(10)
  end

  private

  def conversion_params
    params.permit(:amount, :from, :to)
  end

  def validate_required_params
    unless conversion_params[:amount].present? && conversion_params[:from].present? && conversion_params[:to].present?
      render json: { errors: [ "Missing required parameters: amount, from, and to are required" ] }, status: :bad_request
    end
  end
end
