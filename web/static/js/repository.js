const escapeStringRegexp = require('escape-string-regexp');
const SEARCH_FIELD_CLASS = ".repository-search";
const REPO_FIELD_CLASS = ".repository"

export function repositorySearch() {
    $(SEARCH_FIELD_CLASS).on("keyup", function(element) {
        var searchValue = element.target.value;

        if(searchValue.length == 0){
            $(REPO_FIELD_CLASS).show()
        }
        else{
            filterRepositories(searchRegExp(searchValue))
        }
    });
}

function searchRegExp(searchValue) {
    var regExpString = searchValue.split("").map(function(searchChar) {
        return escapeStringRegexp(searchChar)
    }).join(".*") + ".*";

    return new RegExp(regExpString, "i");
}

function filterRepositories(searchRegExp) {
    $.each($(REPO_FIELD_CLASS), function(_i, repo) {
        var $repo = $(repo);
        var repoName = $repo.text();

        if(repoName.match(searchRegExp)){
            $repo.show();
        }
        else{
            $repo.hide();
        }
    });
}
