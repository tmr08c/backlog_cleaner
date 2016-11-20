import { closeIssue, keepIssue } from 'web/static/js/issue_socket';

const Swing = require('swing');
const Card = Swing.Card;
const config = {
    minThrowOutDistance: 200,
    maxThrowOutDistance: 400,
    throwOutConfidence: (xOffset, element) => {
        return Math.min(Math.abs(xOffset) / (element.offsetWidth / 2), 1);
    }
};
const KEEP_BUTTON_CLASS = ".keep-issue-button";
const CLOSE_BUTTON_CLASS = ".close-issue-button";
const CARD_CLASS = ".issue";
const HIDDEN_CARD_CLASS = `${CARD_CLASS}.hidden`;
const MAX_STACK_SIZE = 5;

export function convertToCard(channel) {
    let issues = $(CARD_CLASS);
    let issuesToShow = [].slice.call(issues, 0, MAX_STACK_SIZE);
    const stack = Swing.Stack(config);

    $(issuesToShow).removeClass("hidden");
    createCard(issuesToShow[0], stack, channel);
    addStackListeners(stack, channel);
};

function createCard(element, stack, channel){
    let $element = $(element);
    // Add card element to the Stack.
    let card = stack.createCard($element[0]);

    $element.addClass("current");

    // Add button listeners
    $element
        .find(KEEP_BUTTON_CLASS)
        .on("click", (event) => {card.throwOut(Card.DIRECTION_RIGHT, 50);});

    $element
        .find(CLOSE_BUTTON_CLASS)
        .on("click", (event) => {card.throwOut(Card.DIRECTION_LEFT, 50);});
};

function addStackListeners(stack, channel){
    stack.on('throwout', (event) => {
        let $issue = $(event.target);

        updateStack(stack, channel);

        switch(event.throwDirection){
        case Card.DIRECTION_LEFT:
            closeIssue($issue, channel);
            break;
        case Card.DIRECTION_RIGHT:
            keepIssue($issue, channel);
            break;
        }
    });
};

function updateStack(stack, channel){
    // make the next shown issue a card
    let nextIssueToMakeCard = $(`${CARD_CLASS}:not(.hidden):not(.current):last`)
    if (nextIssueToMakeCard.length === 0) return;
    createCard(nextIssueToMakeCard, stack, channel);

    // show the next hidden card
    let nextIssue = $(HIDDEN_CARD_CLASS);
    if (nextIssue.length === 0) return;
    $(nextIssue).removeClass("hidden");
}
