dateToIso = (date) -> date.toString 'yyyy-MM-dd'
isoToDate = (iso) -> new XDate iso

class @GanttDate
  date: null
  hour: null
  availableHours: null
  ratio: ->
    return null unless @hour? and @availableHours?
    @hour / @availableHours
  comparable: ->
    "#{@date} #{if @hour < 10 then '0' else ''}#{@hour}"
  constructor: (options) ->
    @set options
  set: (options) ->
    @setDate options.date if options.date?
    @hour = options.hour if options.hour?
    @availableHours = options.availableHours if options.availableHours?
  setDate: (date) ->
    @date = if _.isObject date then dateToIso date else date

GanttDate.dateToIso = dateToIso
GanttDate.isoToDate = isoToDate
