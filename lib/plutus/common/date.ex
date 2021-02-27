defmodule Plutus.Common.Date do
  use Timex

  @weekend_days [7, 6]
  @week_days [1, 2, 3, 4, 5]

  def get_current_date() do
    NaiveDateTime.utc_now()
  end

  def get_beginning_of_month() do
    get_current_date()
    |> Timex.beginning_of_month
  end

  def end_of_month(date) do
    date
    |> Timex.end_of_month
  end

  def get_end_of_month() do
    get_current_date()
    |> Timex.end_of_month
  end

  def one_month_ago() do
    get_current_date
    |> shift_months(-1)
  end

  def day() do
    get_current_date.day
  end

  def month() do
    get_current_date.month
  end

  def year() do
    get_current_date.year
  end

  def shift_months(date, 0), do: date
  def shift_months(date, shift) do
    date
    |> Timex.shift(months: shift)
  end

  def assemble_date_from_day_of_month(day_of_month) do
    {:ok, new_date} = NaiveDateTime.new(year(), month(), day_of_month, 0, 0, 0)
    new_date
  end

  def format_date(date) do
    {date.year, date.month, date.day}
  end

  def is_bank_holiday?(date) do
    {date, _} = Timex.to_erl(date)
    holidays = Holidays.on(date, [:nyse])
    length(holidays) != 0
  end

  def find_next_earliest_business_day(date) do
    previous_day = Timex.shift(date, days: -1)
    if is_business_day?(previous_day) and not is_bank_holiday?(previous_day) do
      previous_day
    else
      find_next_earliest_business_day(previous_day)
    end
  end

  def shift_to_earliest_business_day(date) do
    if is_business_day?(date) and not is_bank_holiday?(date) do
      date
    else
      find_next_earliest_business_day(date)
    end 
  end

  def is_business_day?(date) do
    day_of_week = Date.day_of_week(date)
    Enum.member?(@week_days, day_of_week)
  end

  def parse_date(date) do
    Timex.parse(date, "{YYYY}-{0M}-{0D}")
  end
end