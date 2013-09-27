Augury.Models.Message = Backbone.MongoModel.extend(
  initialize: ->
    @urlRoot = "/stores/#{Augury.store_id}/messages"

  has_errors: ->
    @get('last_error')

  integrationIconUrl: ->
    @get('integration_icon_url') if @get('is_consumer_remote')? && @get('integration_icon_url')?

  state: ->
    if @get('locked_at')?
      'running'
    else
      @get('state')

  archive: ->
    defer = $.Deferred()
    $.ajax
      url: "/stores/#{Augury.store_id}/messages/#{@id}"
      type: "PUT"
      data: archive: true
      success: ->
        Augury.Flash.success 'Message has been archived.'
        defer.resolve(true)
      error: ->
        Augury.Flash.error 'Message could not be archived. Please try again.'
    defer.promise()
)

