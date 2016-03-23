module.exports = (robot) ->

  robot.router.post "/merge_request/:channel", (req, res) ->
    if robot.adapter instanceof slack.SlackBot
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
          name = objectAttr.source.name.toLowerCase()
          iid = objectAttr.iid
          mergeRequestUrl = "#{gitlabUrl}#{nameSpace}/#{name}/merge_requests/#{iid}"

          formatDate = (d) ->
            year   = d.getUTCFullYear()
            month  = "0#{d.getUTCMonth() + 1}".slice(-2)
            date   = "0#{d.getUTCDate()}".slice(-2)
            hour   = "0#{d.getUTCHours() + 9}".slice(-2)
            minute = "0#{d.getUTCMinutes()}".slice(-2)
            second = "0#{d.getUTCSeconds()}".slice(-2)
            return "#{year}/#{month}/#{date} #{hour}:#{minute}:#{second}"
          createTime = formatDate createdAt

          envelope = room: req.params.channel
          robot.send envelope, """
          Merge Request ##{iid} created by #{body.user.name} at #{createTime}
          #{mergeRequestUrl}
          >>>
          *#{title}*
          #{description}
          >>>
          """

    res.set 'Content-Type', 'application/json'
    res.send '{"status": 200}'
