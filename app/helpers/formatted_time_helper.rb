module FormattedTimeHelper
  DAY_NAMES = ['domingo', 'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo']
  MONTH_NAMES = ['', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre']

  def week_day_name(date)
    DAY_NAMES[date.wday].capitalize
  end

  def short_formated_date(date)
    [date.strftime("%d"), MONTH_NAMES[date.month.to_i].capitalize, date.year].join('/')
  end

  def long_formated_time(date)
    date.strftime("%I:%M %P")
  end
end
