module.exports = (robot) ->

  robot.router.post "/merge_request/:channel", (req, res) ->
    responseJson = '{"err": null}'
    try
      channel = req.params?.channel
      body = req.body

      if channel? and body?
        object_kind = body.object_kind
        state = body.object_attributes?.state
        if object_kind is 'merge_request' and state is 'opened'

          oa = body.object_attributes
          createdAt = oa.created_at
          updatedAt = oa.updated_at

          if createdAt is updatedAt
            title = oa.title
            description = oa.description

            gitlabUrl = process.env.GITLAB_URL or '/'
            if not /\/$/m.test gitlabUrl
              gitlabUrl = "#{gitlabUrl}/"
            nameSpace = oa.source.namespace.toLowerCase().replace /[ ]/g, '-'
            name = encodeURIComponent oa.source.name.toLowerCase()
            iid = oa.iid
            url = "#{gitlabUrl}#{nameSpace}/#{name}/merge_requests/#{iid}"

            envelope = room: req.params.channel
            robot.send envelope, """
            <!channel>
            Merge Request ##{iid} created by #{body.user.name}
            at #{createdAt}
            #{url}
            >>>
            *#{title}*
            #{description}
            """

    catch error
      responseJson = "{\"err\": \"#{error}\", \"req\": \"#{req}\"}"

    res.set 'Content-Type', 'application/json'
    res.send responseJson
