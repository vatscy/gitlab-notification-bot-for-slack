module.exports = (robot) ->

  robot.router.post "/merge_request/:channel", (req, res) ->
    responseJson = '{"err": null}'
    try
      channel = req.params?.channel
      body = req.body

      if channel? and body? and body.object_kind is 'merge_request' and body.object_attributes?.state is 'opened'
        objectAttr = body.object_attributes
        createdAt = objectAttr.created_at
        updatedAt = objectAttr.updated_at

        if createdAt is updatedAt
          title = objectAttr.title
          description = objectAttr.description

          gitlabUrl = process.env.GITLAB_URL or '/'
          if not /\/$/m.test gitlabUrl
            gitlabUrl = "#{gitlabUrl}/"
          nameSpace = objectAttr.source.namespace.toLowerCase().replace /[ ]/g, '-'
          name = encodeURIComponent objectAttr.source.name.toLowerCase()
          iid = objectAttr.iid
          mergeRequestUrl = "#{gitlabUrl}#{nameSpace}/#{name}/merge_requests/#{iid}"

          envelope = room: req.params.channel
          robot.send envelope, """
          Merge Request ##{iid} created by #{body.user.name} at #{createdAt}
          #{mergeRequestUrl}
          >>>
          *#{title}*
          #{description}
          """
    catch error
      responseJson = "{\"err\": \"#{error}\", \"req\": \"#{req}\"}"

    res.set 'Content-Type', 'application/json'
    res.send responseJson
