chai = require 'chai'
chai.should()
expect = chai.expect

moment = require 'moment'
Issue = require '../lib/Issue'

describe 'Issue', ->
  before ->
    @statusMap =
      todo: [
        'todo'
        'open'
      ]
      inProgress: [
        'in progress'
        'ready for merging'
      ]
      done: [
        'done'
        'closed'
      ],
      ignore: [
      ]
    @userMap =
      developers: [
        'user1'
        'user2'
        'user3'
      ]
      ignore: [
        'user0'
      ]
    @Issue = Issue @statusMap, @userMap

  it 'should export initial columns', ->
    @Issue.columns.should.deep.equal [
      'key'
      'status'
      'created'
      'closed'
      'leadTime'
      'cycleTime'
      'deferredTime'
      'type'
      'parentStatus'
      'parentPriority'
      'parentType'
      'priority'
      'resolution'
    ]

  it 'should export initial labels', ->
    @Issue.labels.should.deep.equal []

  it 'should export initial components', ->
    @Issue.components.should.deep.equal []

  it 'should export initial types', ->
    @Issue.types.should.deep.equal []

  it 'should export initial priorities', ->
    @Issue.priorities.should.deep.equal []

  it 'should export initial resolutions', ->
    @Issue.resolutions.should.deep.equal []

  it 'should export initial unknown statuses', ->
    @Issue.unknownStatuses.should.deep.equal []

  it 'should export initial unknown users', ->
    @Issue.unknownUsers.should.deep.equal []

  describe 'from new issue with no changelog', ->
    before ->
      @Issue = Issue @statusMap, @userMap
      @rawIssue =
        key: 'key-1'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          status:
            name: 'unknownStatus'
          issuetype:
            name: 'sub-task'
          priority:
            name: 'p1'
          parent:
            fields:
              issuetype:
                name: 'bug'
              status:
                name: 'todo'
              priority:
                name: 'p2'
          labels: [
            'label1'
            'label2'
          ]
          components: [
            name: 'component1'
          ,
            name: 'component2'
          ]
        changelog:
          histories: []
      @issue = new @Issue @rawIssue

    it 'should initialise key', ->
      @issue.key.should.equal 'key-1'

    it 'should initialise status', ->
      @issue.status.should.equal 'unknownStatus'

    it 'should initialise display created date', ->
      @issue.created.should.equal '2015/01/20'

    it 'should initialise display closed date', ->
      expect(@issue.closed).to.be.undefined

    it 'should initialise lead time', ->
      expect(@issue.leadTime).to.be.undefined

    it 'should initialise cycle time', ->
      expect(@issue.cycleTime).to.be.undefined

    it 'should initialise deferred time', ->
      expect(@issue.deferredTime).to.be.undefined

    it 'should initialise type', ->
      @issue.type.should.equal 'sub-task'

    it 'should initialise priority', ->
      @issue.priority.should.equal 'p1'

    it 'should initialise resolution', ->
      expect(@issue.resolution).to.be.undefined

    it 'should initialise parent status', ->
      @issue.parentStatus.should.equal 'todo'

    it 'should initialise parent priority', ->
      @issue.parentPriority.should.equal 'p2'

    it 'should initialise parent type', ->
      @issue.parentType.should.equal 'bug'

    it 'should initialise labels', ->
      @issue['label.label1'].should.equal 'yes'
      @issue['label.label2'].should.equal 'yes'

    it 'should initialise components', ->
      @issue['component.component1'].should.equal 'yes'
      @issue['component.component2'].should.equal 'yes'

    it 'should append to Issue labels', ->
      @Issue.labels.should.deep.equal [
        'label1'
        'label2'
      ]

    it 'should append to Issue components', ->
      @Issue.components.should.deep.equal [
        'component1'
        'component2'
      ]

    it 'should append to Issue types', ->
      @Issue.types.should.deep.equal [
        'sub-task'
      ]

    it 'should append to Issue priorities', ->
      @Issue.priorities.should.deep.equal [
        'p1'
      ]

    it 'should append to Issue columns', ->
      @Issue.columns.should.deep.equal [
        'key'
        'status'
        'created'
        'closed'
        'leadTime'
        'cycleTime'
        'deferredTime'
        'type'
        'parentStatus'
        'parentPriority'
        'parentType'
        'priority'
        'resolution'
        'label.label1'
        'label.label2'
        'component.component1'
        'component.component2'
      ]

    it 'should append to Issue unknown statuses', ->
      @Issue.unknownStatuses.should.deep.equal [
        'unknownStatus'
      ]

    describe '#hasLabel', ->
      it 'should return true if issue has label', ->
        @issue.hasLabel('label1').should.be.true

      it 'should return false if issue does not have label', ->
        @issue.hasLabel('label3').should.be.false

    describe '#affectsComponent', ->
      it 'should return true if issue affects component', ->
        @issue.affectsComponent('component1').should.be.true

      it 'should return false if issue does not affect component', ->
        @issue.affectsComponent('component3').should.be.false

    describe '#openOnDate', ->
      it 'should return true if date is after created', ->
        date = moment '2015-01-22T11:19:48.633+0000'
        @issue.openOnDate(date).should.be.true

    describe '#openedOnDate', ->
      it 'should return true if date is the day created', ->
        date = moment '2015-01-20T12:19:48.633+0000'
        @issue.openedOnDate(date).should.be.true

      it 'should return false if date is not the day created', ->
        date = moment '2015-01-21T12:19:48.633+0000'
        @issue.openedOnDate(date).should.be.false

    describe '#closedOnDate', ->
      it 'should return false if issue is not done', ->
        date = moment '2015-01-20T12:19:48.633+0000'
        @issue.closedOnDate(date).should.be.false

    describe '#technicalDebtOnDate', ->
      it 'should return 0 if date is before created', ->
        date = moment '2015-01-19T11:19:48.633+0000'
        @issue.technicalDebtOnDate(date).should.equal 0

      it 'should return number of days open if date is after created', ->
        date = moment '2015-01-22T11:19:48.633+0000'
        @issue.technicalDebtOnDate(date).should.equal 2

    describe '#resolvedDays', ->
      it 'should return null', ->
        date = moment '2015-01-22T11:19:48.633+0000'
        expect(@issue.resolvedDays(date)).to.be.null

  describe 'from closed issue', ->
    before ->
      @Issue = Issue @statusMap, @userMap
      @rawIssue =
        key: 'key-2'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          resolutiondate: '2015-01-26T11:19:48.633+0000'
          status:
            name: 'done'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          resolution:
            name: 'fixed'
          labels: [
            'label1'
            'label2'
          ]
          components: [
            name: 'component1'
          ,
            name: 'component2'
          ]
        changelog:
          histories: [
            author:
              name: 'user0'
            created: '2015-01-21T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'unknownStatus1'
            ]
          ,
            author:
              name: 'user1'
            created: '2015-01-21T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'unknownStatus2'
            ]
          ,
            author:
              name: 'unknownUser1'
            created: '2015-01-22T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'unknownUser2'
            ]
          ,
            author:
              name: 'unknownUser2'
            created: '2015-01-24T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'in progress'
            ]
          ,
            author:
              name: 'unknownUser2'
            created: '2015-01-26T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'unknownUser3'
            ,
              field: 'status'
              toString: 'done'
            ]
          ]
      @issue = new @Issue @rawIssue

    it 'should initialise display closed date', ->
      @issue.closed.should.equal '2015/01/26'

    it 'should initialise lead time', ->
      @issue.leadTime.should.equal 6

    it 'should initialise cycle time', ->
      @issue.cycleTime.should.equal 2

    it 'should initialise deferred time', ->
      @issue.deferredTime.should.equal 4

    it 'should initialise resolution', ->
      @issue.resolution.should.equal 'fixed'

    it 'should initialise parent status', ->
      expect(@issue.parentStatus).to.be.undefined

    it 'should initialise parent priority', ->
      expect(@issue.parentPriority).to.be.undefined

    it 'should initialise parent type', ->
      expect(@issue.parentType).to.be.undefined

    it 'should append to Issue resolutions', ->
      @Issue.resolutions.should.deep.equal [
        'fixed'
      ]

    it 'should append to Issue unknown users', ->
      @Issue.unknownUsers.should.deep.equal [
        'unknownUser1'
        'unknownUser2'
        'unknownUser3'
      ]

    it 'should append to Issue unknown statuses', ->
      @Issue.unknownStatuses.should.deep.equal [
        'unknownStatus1'
        'unknownStatus2'
      ]

    describe '#openOnDate', ->
      it 'should return false if date is before created', ->
        date = moment '2015-01-19T11:19:48.633+0000'
        @issue.openOnDate(date).should.be.false

      it 'should return true if date is between created and done', ->
        date = moment '2015-01-22T11:19:48.633+0000'
        @issue.openOnDate(date).should.be.true

      it 'should return false if date is after done', ->
        date = moment '2015-01-27T11:19:48.633+0000'
        @issue.openOnDate(date).should.be.false

    describe '#closedOnDate', ->
      it 'should return true if date is on the closed day', ->
        date = moment '2015-01-26T12:19:48.633+0000'
        @issue.closedOnDate(date).should.be.true

      it 'should return false if date is not on the closed day', ->
        date = moment '2015-01-25T12:19:48.633+0000'
        @issue.closedOnDate(date).should.be.false

    describe '#technicalDebtOnDate', ->
      it 'should return 0 if date is after done', ->
        date = moment '2015-01-27T11:19:48.633+0000'
        @issue.technicalDebtOnDate(date).should.equal 0

    describe '#resolvedDays', ->
      it 'should return zero if resolved on the given date', ->
        date = moment '2015-01-26T11:19:48.633+0000'
        @issue.resolvedDays(date).should.equal 0

# coffeelint: disable=max_line_length
      it 'should return number of days since resolved for a date after resolution', ->
# coffeelint: enable=max_line_length
        date = moment '2015-01-29T11:19:48.633+0000'
        @issue.resolvedDays(date).should.equal 3

# coffeelint: disable=max_line_length
      it 'should return negative number of days to resolved for a date before resolution', ->
# coffeelint: enable=max_line_length
        date = moment '2015-01-23T11:19:48.633+0000'
        @issue.resolvedDays(date).should.equal -3

  describe 'from closed issue with missing resolutiondate', ->
    before ->
      @Issue = Issue @statusMap, @userMap
      @rawIssue =
        key: 'key-2'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          status:
            name: 'done'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          resolution:
            name: 'fixed'
          labels: [
            'label1'
            'label2'
          ]
          components: [
            name: 'component1'
          ,
            name: 'component2'
          ]
        changelog:
          histories: [
            author:
              name: 'user2'
            created: '2015-01-22T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'user1'
            ]
          ,
            author:
              name: 'user1'
            created: '2015-01-24T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'in progress'
            ]
          ,
            author:
              name: 'user1'
            created: '2015-01-26T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'user2'
            ,
              field: 'status'
              toString: 'done'
            ]
          ]
      @issue = new @Issue @rawIssue

    it 'should initialise display closed date', ->
      @issue.closed.should.equal '2015/01/26'

# coffeelint: disable=max_line_length
  describe 'from closed issue with missing resolutiondate and no status changes', ->
# coffeelint: enable=max_line_length
    before ->
      @Issue = Issue @statusMap, @userMap
      @rawIssue =
        key: 'key-2'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          status:
            name: 'done'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          labels: [
            'label1'
            'label2'
          ]
          components: [
            name: 'component1'
          ,
            name: 'component2'
          ]
        changelog:
          histories: []
      @issue = new @Issue @rawIssue

    it 'should initialise display closed date to equal the created date', ->
      @issue.closed.should.equal '2015/01/20'

  describe '#checkCycleTime', ->
    before ->
      @Issue = Issue @statusMap, @userMap, 300
      immediatelyClosedIssue = (key, created, assigned, done, user) ->
        key: key
        fields:
          created: created
          status:
            name: 'done'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          resolution:
            name: 'fixed'
          labels: []
          components: []
        changelog:
          histories: [
            author:
              name: 'user0'
            created: assigned
            items: [
              field: 'assignee'
              to: user
            ]
          ,
            author:
              name: user
            created: done
            items: [
              field: 'assignee'
              to: 'user0'
            ,
              field: 'status'
              toString: 'done'
            ]
          ]
      immediatelyClosedAndReopenedIssue = (
        key
        created
        assigned
        done
        user
        reopened
        secondDone
        secondUser
      ) ->
        key: key
        fields:
          created: created
          status:
            name: 'done'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          resolution:
            name: 'fixed'
          labels: []
          components: []
        changelog:
          histories: [
            author:
              name: 'user0'
            created: assigned
            items: [
              field: 'assignee'
              to: user
            ]
          ,
            author:
              name: user
            created: done
            items: [
              field: 'assignee'
              to: 'user0'
            ,
              field: 'status'
              toString: 'done'
            ]
          ,
            author:
              name: 'user0'
            created: reopened
            items: [
              field: 'assignee'
              to: secondUser
            ,
              field: 'status'
              toString: 'todo'
            ]
          ,
            author:
              name: secondUser
            created: secondDone
            items: [
              field: 'assignee'
              to: 'user0'
            ,
              field: 'status'
              toString: 'done'
            ]
          ]
      @issue1 = new @Issue immediatelyClosedIssue(
        'key-1'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-22T11:19:48.633+0000'
        '2015-01-24T11:19:48.633+0000'
        'user1'
      )
      @issue2 = new @Issue immediatelyClosedIssue(
        'key-2'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-23T11:19:48.633+0000'
        '2015-01-25T11:19:48.633+0000'
        'user2'
      )
      @issue3 = new @Issue immediatelyClosedIssue(
        'key-3'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-22T11:19:48.633+0000'
        '2015-01-26T11:19:48.633+0000'
        'user1'
      )
      @issue4 = new @Issue immediatelyClosedIssue(
        'key-4'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-24T11:19:48.633+0000'
        '2015-01-28T11:19:48.633+0000'
        'user2'
      )
      @issue5 = new @Issue immediatelyClosedIssue(
        'key-5'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-24T11:19:48.633+0000'
        '2015-01-27T11:19:48.633+0000'
        'user1'
      )
      @issue6 = new @Issue immediatelyClosedIssue(
        'key-6'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-25T11:19:48.633+0000'
        '2015-01-30T11:19:48.633+0000'
        'user2'
      )
      @issue7 = new @Issue immediatelyClosedAndReopenedIssue(
        'key-7'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-25T11:19:48.633+0000'
        '2015-01-30T11:19:48.633+0000'
        'user1'
        '2015-01-31T11:19:48.633+0000'
        '2015-02-02T11:19:48.633+0000'
        'user1'
      )
      @issue8 = new @Issue immediatelyClosedAndReopenedIssue(
        'key-8'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-25T11:19:48.633+0000'
        '2015-02-04T11:19:48.633+0000'
        'user2'
        '2015-02-05T11:19:48.633+0000'
        '2015-02-08T11:19:48.633+0000'
        'user1'
      )
      @issue9 = new @Issue immediatelyClosedIssue(
        'key-9'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-25T11:19:48.633+0000'
        '2015-01-30T11:19:48.633+0000'
        'user0'
      )
      @issue10 = new @Issue immediatelyClosedIssue(
        'key-10'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-25T11:19:48.633+0000'
        '2015-01-31T11:19:48.633+0000'
        'user0'
      )
      @issue11 = new @Issue immediatelyClosedIssue(
        'key-11'
        '2015-01-20T11:19:48.633+0000'
        '2015-01-25T11:19:48.633+0000'
        '2015-01-31T11:19:48.633+0000'
        'user3'
      )
      @issue12 = new @Issue immediatelyClosedIssue(
        'key-12'
        '2015-02-20T11:19:48.633+0000'
        '2015-02-25T11:19:48.633+0000'
        '2015-02-28T11:19:48.633+0000'
        'user3'
      )

# coffeelint: disable=max_line_length
    it 'should not calculate a new cycle time if the closing user did not close an issue before it', ->
# coffeelint: enable=max_line_length
      @issue1.cycleTime.should.equal 0
      @issue1.leadTime.should.equal 4
      @issue1.deferredTime.should.equal 4
      @issue1.checkCycleTime()
      @issue1.cycleTime.should.equal 0
      @issue1.leadTime.should.equal 4
      @issue1.deferredTime.should.equal 4
      @issue2.cycleTime.should.equal 0
      @issue2.leadTime.should.equal 5
      @issue2.deferredTime.should.equal 5
      @issue2.checkCycleTime()
      @issue2.cycleTime.should.equal 0
      @issue2.leadTime.should.equal 5
      @issue2.deferredTime.should.equal 5

# coffeelint: disable=max_line_length
    it 'should calculate a new cycle time if the current cycle time is less than the minimum trusted cycle time', ->
# coffeelint: enable=max_line_length
      @issue3.cycleTime.should.equal 0
      @issue3.leadTime.should.equal 6
      @issue3.deferredTime.should.equal 6
      @issue3.checkCycleTime()
      @issue3.cycleTime.should.equal 2
      @issue3.leadTime.should.equal 6
      @issue3.deferredTime.should.equal 4
      @issue4.cycleTime.should.equal 0
      @issue4.leadTime.should.equal 8
      @issue4.deferredTime.should.equal 8
      @issue4.checkCycleTime()
      @issue4.cycleTime.should.equal 3
      @issue4.leadTime.should.equal 8
      @issue4.deferredTime.should.equal 5
      @issue5.cycleTime.should.equal 0
      @issue5.leadTime.should.equal 7
      @issue5.deferredTime.should.equal 7
      @issue5.checkCycleTime()
      @issue5.cycleTime.should.equal 1
      @issue5.leadTime.should.equal 7
      @issue5.deferredTime.should.equal 6
      @issue6.cycleTime.should.equal 0
      @issue6.leadTime.should.equal 10
      @issue6.deferredTime.should.equal 10
      @issue6.checkCycleTime()
      @issue6.cycleTime.should.equal 2
      @issue6.leadTime.should.equal 10
      @issue6.deferredTime.should.equal 8

# coffeelint: disable=max_line_length
    it 'should take into account cases where issues are reopened and fixed by the same user', ->
# coffeelint: enable=max_line_length
      @issue7.cycleTime.should.equal 0
      @issue7.leadTime.should.equal 13
      @issue7.deferredTime.should.equal 13
      @issue7.checkCycleTime()
      @issue7.cycleTime.should.equal 6
      @issue7.leadTime.should.equal 13
      @issue7.deferredTime.should.equal 7

# coffeelint: disable=max_line_length
    it 'should take into account cases where issues are reopened and fixed by a different user', ->
# coffeelint: enable=max_line_length
      @issue8.cycleTime.should.equal 0
      @issue8.leadTime.should.equal 19
      @issue8.deferredTime.should.equal 19
      @issue8.checkCycleTime()
      @issue8.cycleTime.should.equal 11
      @issue8.leadTime.should.equal 19
      @issue8.deferredTime.should.equal 8

    it 'should not count cases where an issue is closed by a non developer', ->
      @issue9.cycleTime.should.equal 0
      @issue9.leadTime.should.equal 10
      @issue9.deferredTime.should.equal 10
      @issue9.checkCycleTime()
      @issue9.cycleTime.should.equal 0
      @issue9.leadTime.should.equal 10
      @issue9.deferredTime.should.equal 10
      @issue10.cycleTime.should.equal 0
      @issue10.leadTime.should.equal 11
      @issue10.deferredTime.should.equal 11
      @issue10.checkCycleTime()
      @issue10.cycleTime.should.equal 0
      @issue10.leadTime.should.equal 11
      @issue10.deferredTime.should.equal 11

    it 'should not set a negative deferred time', ->
      @issue12.cycleTime.should.equal 0
      @issue12.leadTime.should.equal 8
      @issue12.deferredTime.should.equal 8
      @issue12.checkCycleTime()
      @issue12.cycleTime.should.equal 8
      @issue12.leadTime.should.equal 8
      @issue12.deferredTime.should.equal 0

  describe 'accumulators', ->
    before ->
      @Issue = Issue @statusMap, @userMap, 300
      rawIssue =
        key: 'key-1'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          status:
            name: 'done'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          resolution:
            name: 'fixed'
          labels: [
            'label1'
            'label2'
          ]
          components: [
            name: 'component1'
          ,
            name: 'component2'
          ]
        changelog:
          histories: []
      issue = new @Issue rawIssue
      issue = new @Issue rawIssue
      issue = new @Issue rawIssue

    it 'should only accumulate unique types', ->
      @Issue.types.should.deep.equal [
        'bug'
      ]

    it 'should only accumulate unique priorities', ->
      @Issue.priorities.should.deep.equal [
        'p1'
      ]

    it 'should only accumulate unique resolutions', ->
      @Issue.resolutions.should.deep.equal [
        'fixed'
      ]

    it 'should only accumulate unique labels', ->
      labelColumns = @Issue.columns.filter (column) ->
        column.indexOf('label.') == 0
      labelColumns.should.deep.equal([
        'label.label1'
        'label.label2'
      ])
      @Issue.labels.should.deep.equal [
        'label1'
        'label2'
      ]

    it 'should only accumulate unique components', ->
      componentColumns = @Issue.columns.filter (column) ->
        column.indexOf('component.') == 0
      componentColumns.should.deep.equal([
        'component.component1'
        'component.component2'
      ])
      @Issue.components.should.deep.equal [
        'component1'
        'component2'
      ]
