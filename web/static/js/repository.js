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
            filterRepositories(searchValue)
        }
    });
}


function filterRepositories(searchValue) {
    $.each($(REPO_FIELD_CLASS), function(_i, repo) {
        var $repo = $(repo);
        var repoName = $repo.find("a").text();
        searchValue = escapeStringRegexp(searchValue);
        var searchRegExp = new RegExp(searchValue.split("").join(".*") + ".*", "i")

        if(repoName.match(searchRegExp)){
            $repo.show();
        }
        else{
            $repo.hide();
        }
    });
}
