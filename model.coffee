Snacks = new Meteor.Collection('snacks')
Answers = new Meteor.Collection('answers')


if Meteor.is_client
  Template.snacklist.snacks = ->
    Snacks.find {}
  Template.selectedsnack.snack = ->
    selected = Session.get("selected_snack")
    snack = Snacks.findOne { _id: selected }
    return snack

  Template.mainarea.newsnackmode = ->
    Session.equals("selected_snack", undefined)

  Template.account.current = ->
    Session.get("name")

  Template.snack.answers = ->
    Answers.find { snack_id: Session.get("selected_snack") }

  Template.snack.hasanswers = ->
    return Answers.find({ snack_id: Session.get("selected_snack") }).count() > 0

  Template.newsnack.loggedin = Template.snacklist.loggedin = Template.snack.loggedin = ->
    !Session.equals("name", undefined)

  Template.snacklist.loggedin = ->
    !Session.equals("name", undefined)

  Template.snacklist.events = {
    'click .snacklabel': (event) ->
      Session.set("selected_snack", this._id)
    'click input.new': ->
      Session.set("selected_snack", undefined)
  }

  newsnack = ->
    snack = {}
    snack.name = $(".newsnack .name").val()
    snack.description = $(".newsnack .description").val()
    $(".newsnack .name").val("")
    $(".newsnack .description").val("")
    snack.author = Session.get("name")
    Snacks.insert( snack )

  Template.newsnack.events = {
    'click .submit': -> 
      newsnack()
  }

  Template.account.events = {
    'click input.submit': (event) ->
      Session.set("name", $("input.name").val())
    'keydown input.name': (event) ->
      if event.keyCode == 13
        Session.set("name", $("input.name").val())
  }

  Template.snack.events = {
    'click .newanswer input.submit': (event) ->
      Answers.insert( { snack_id: Session.get("selected_snack"), body: $(".newanswer #body").val(), author: Session.get("name") } ) 
      $(".newanswer #body").val("")

  }

# On server startup, create some players if the database is empty.
if Meteor.is_server
  Meteor.startup ->
    if Snacks.find().count() == 0 
      names = ["Thyme", "Imagine"]
      descriptions = ["Write a rhyme to do with thyme.",
                      "What would you do if you found a gold bar."]
      author = "Server"
      for i in [0..1]            
        Snacks.insert {name: names[i], description: descriptions[i], author: author} 
