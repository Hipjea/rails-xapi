# frozen_string_literal: true

class ApplicationService
  def self.call(*, &)
    new(*args, &block).call
  end

  private

  # Set the start_date to the first day of the given month and year,
  # and the end_date to the last day of the givenn month.
  private_class_method def self.generate_start_date_end_date(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    [start_date, end_date]
  end
end
