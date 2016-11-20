import socket from "./socket";

export function join(){
    let channel = socket.channel("issues:lobby", {});
    channel.join()
        .receive("ok", resp => {
            console.log("Joined successfully", resp);
        })
        .receive("error", resp => {
            console.log("Unable to join", resp);
        });

    return channel;
};

export function closeIssue(issue, channel){
    let issueData = issue.data();

    channel.push("issues:close", issueData)
        .receive("ok", () => {
            console.log("successfully closed issue");
            issue.remove();
        })
        .receive("error", (reasons) => {
            console.log("failed to close issue", reasons);
        });
};

export function keepIssue(issue, channel){
    let issueData = issue.data();

    channel.push("issues:keep", issueData)
        .receive("ok", () => {
            console.log("successfully kept issue");
            issue.remove();
        })
        .receive("error", (reasons) => {
            console.log("failed to keep issue", reasons);
        });
};
