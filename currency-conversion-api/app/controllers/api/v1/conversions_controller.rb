class Api::V1::ConversionsController < ApplicationController
  def create
    amount = BigDecimal(conversion_params[:amount])
    from   = conversion_params[:from]
    to     = conversion_params[:to]

    conversion_data = ConversionService.convert(amount: amount, from: from, to: to)

    if @conversion = Conversion.create(conversion_data)
      render :create, status: :created
    else
      render json: { errors: @conversion.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    @conversions = Conversion.order(created_at: :desc)
  end

  private

  def conversion_params
    params.permit(:amount, :from, :to)
  end
end
