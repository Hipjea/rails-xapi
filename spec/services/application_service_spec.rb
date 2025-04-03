require "rails_helper"

RSpec.describe ApplicationService do
  describe "call" do
    let(:service_class) do
      Class.new(ApplicationService) do
        def call
          {status: 200}
        end
      end
    end

    it "instantiates and calls the service" do
      expect(service_class.call).to eq({status: 200})
    end
  end

  describe "generate_start_date_end_date" do
    it "returns the first and last date of the given month and year" do
      year = 2025
      month = 1

      start_date, end_date = ApplicationService.send(:generate_start_date_end_date, year, month)

      expect(start_date).to eq(Date.new(2025, 1, 1))
      expect(end_date).to eq(Date.new(2025, 1, 31))
    end
  end
end
