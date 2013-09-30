Augury.Views.Queues.Stats = Backbone.View.extend(
  template: JST['admin/templates/queues/stats']

  initialize: (@options={}) ->
    @model.on 'reset', @render, @

  events:
    'click li#pending-messages':   'filterPending'
    'click li#failing-messages':   'filterFailing'
    'click li#scheduled-messages': 'filterScheduled'
    'click li#parked-messages':    'filterParked'

  render: ->
    @$el.html @template(model: @model, queue_name: @options.queue_name)
    @

  filterPending: ->
    Backbone.history.navigate('queues/accepted/pending', trigger: true)

  filterFailing: ->
    Backbone.history.navigate('queues/accepted/failing', trigger: true)

  filterScheduled: ->
    Backbone.history.navigate('queues/accepted/scheduled', trigger: true)

  filterParked: ->
    Backbone.history.navigate('queues/accepted/parked', trigger: true)
)

