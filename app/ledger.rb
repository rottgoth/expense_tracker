require_relative '../config/sequel'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    def record(expense)
      validate_presence_of(expense, 'payee').tap { |error| return error if error }
      validate_presence_of(expense, 'amount').tap { |error| return error if error }
      validate_presence_of(expense, 'date').tap { |error| return error if error }

      DB[:expenses].insert(expense)
      id = DB[:expenses].max(:id)
      RecordResult.new(true, id, nil)
    end

    def expenses_on(date)
      DB[:expenses].where(date: date).all
    end

    private

    def validate_presence_of(expense, attribute)
      unless expense.key?(attribute)
        message = "Invalid expense `#{attribute}` is required"
        return RecordResult.new(false, nil, message)
      end
    end
  end
end