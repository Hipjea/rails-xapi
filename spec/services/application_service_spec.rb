require "rails_helper"

RSpec.describe ApplicationService do
  describe "call" do
    let(:service_class) do
      Class.new(ApplicationService) do
        def call
<<<<<<< HEAD
          { status: 200 }
=======
          {status: 200}
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187
        end
      end
    end

    it "instantiates and calls the service" do
<<<<<<< HEAD
      expect(service_class.call).to eq({ status: 200 })
=======
      expect(service_class.call).to eq({status: 200})
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187
    end
  end

  describe "generate_start_date_end_date" do
    it "returns the first and last date of the given month and year" do
      year = 2025
      month = 1

<<<<<<< HEAD
      start_date, end_date =
        ApplicationService.send(:generate_start_date_end_date, year, month)
=======
      start_date, end_date = ApplicationService.send(:generate_start_date_end_date, year, month)
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187

      expect(start_date).to eq(Date.new(2025, 1, 1))
      expect(end_date).to eq(Date.new(2025, 1, 31))
    end
  end
end
