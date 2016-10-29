export function repositorySearch() {
    $(".repository-search").on("keyup", function(element) {
        var searchValue = element.target.value;

        if(searchValue.length == 0){
            $(".repository").show()
        }
        else{
            filterRepositories(searchValue)
        }
    });
}


function filterRepositories(searchValue) {
    $.each($(".repository"), function(_i, repo) {
        var $repo = $(repo);
        var repoName = $repo.find("a").text();

        if(repoName.match(searchValue)){
            $repo.show();
        }
        else{
            $repo.hide();
        }
    });
}
