_.constructor("Views.UnrankedCandidateLi", Views.CandidateLi, {
  candidateIcon: function() { with(this.builder) {
    div({'class': "candidateIcon candidateRanked", style: "display: none;"})
      .ref('candidateRankedIcon');
  }},

  additionalClass: "unranked",

  viewProperties: {
    initialize: function($super) {
      $super();
      var rankingRelation = this.candidate.rankingByCurrentUser();

      if (!rankingRelation.empty()) {
        this.candidateRankedIcon.show();
      }

      rankingRelation.onInsert(function() {
        this.candidateRankedIcon.show();
      }, this);

      rankingRelation.onRemove(function() {
        this.candidateRankedIcon.hide();
      }, this);

      this.draggable({
        connectToSortable: "ol#rankedCandidates",
        revert: 'invalid',
        revertDuration: 100,
        helper: 'clone',
        zIndex: 100,
        cancel: '.expandArrow, .tooltipIcon, .noDrag'
      });
    }
  }
});