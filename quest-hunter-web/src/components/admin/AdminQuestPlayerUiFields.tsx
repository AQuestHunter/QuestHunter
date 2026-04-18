import type { Dispatch, SetStateAction } from 'react'
import { DEFAULT_QUEST_UI } from '../../lib/questUiDefaults'
import type { QuestUiDraft } from '../../lib/questUiDefaults'

type Props = {
  uiDraft: QuestUiDraft
  setUiDraft: Dispatch<SetStateAction<QuestUiDraft>>
}

export function AdminQuestPlayerUiFields({ uiDraft, setUiDraft }: Props) {
  return (
    <div className="admin-player-ui-stack">
      <details className="admin-nested-details" open>
        <summary className="mono small admin-nested-summary">Intro &amp; loading</summary>
        <label className="field">
          <span className="mono label-text">Intro kicker</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.introKicker}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.introKicker}
            onChange={(e) => setUiDraft((u) => ({ ...u, introKicker: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Intro button</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.introCta}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.introCta}
            onChange={(e) => setUiDraft((u) => ({ ...u, introCta: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Loading message</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.loadingMessage}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.loadingMessage}
            onChange={(e) => setUiDraft((u) => ({ ...u, loadingMessage: e.target.value }))}
          />
        </label>
      </details>

      <details className="admin-nested-details">
        <summary className="mono small admin-nested-summary">Puzzle step labels</summary>
        <label className="field">
          <span className="mono label-text">Challenge badge</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.challengeBadge}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.challengeBadge}
            onChange={(e) => setUiDraft((u) => ({ ...u, challengeBadge: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Hint label</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.hintLabel}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.hintLabel}
            onChange={(e) => setUiDraft((u) => ({ ...u, hintLabel: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Answer placeholder</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.answerPlaceholder}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.answerPlaceholder}
            onChange={(e) => setUiDraft((u) => ({ ...u, answerPlaceholder: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Submit button</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.submitLabel}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.submitLabel}
            onChange={(e) => setUiDraft((u) => ({ ...u, submitLabel: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Submit busy state</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.submitBusyLabel}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.submitBusyLabel}
            onChange={(e) => setUiDraft((u) => ({ ...u, submitBusyLabel: e.target.value }))}
          />
        </label>
      </details>

      <details className="admin-nested-details">
        <summary className="mono small admin-nested-summary">Finale screen</summary>
        <label className="field">
          <span className="mono label-text">Finale badge</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.finaleBadge}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.finaleBadge}
            onChange={(e) => setUiDraft((u) => ({ ...u, finaleBadge: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Finale headline</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.finaleHeadline}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.finaleHeadline}
            onChange={(e) => setUiDraft((u) => ({ ...u, finaleHeadline: e.target.value }))}
          />
        </label>

        <div className="admin-branch-ui-grid">
          <fieldset className="admin-branch-ui-card">
            <legend className="mono small">CONTROL path</legend>
            <label className="field">
              <span className="mono label-text">Kicker</span>
              <input
                className="terminal-input mono"
                value={uiDraft.branchControlKicker}
                onChange={(e) => setUiDraft((u) => ({ ...u, branchControlKicker: e.target.value }))}
              />
            </label>
            <label className="field">
              <span className="mono label-text">Title</span>
              <input
                className="terminal-input mono"
                value={uiDraft.branchControlTitle}
                onChange={(e) => setUiDraft((u) => ({ ...u, branchControlTitle: e.target.value }))}
              />
            </label>
            <label className="field">
              <span className="mono label-text">Description</span>
              <textarea
                className="terminal-input mono tall"
                rows={2}
                value={uiDraft.branchControlDesc}
                onChange={(e) => setUiDraft((u) => ({ ...u, branchControlDesc: e.target.value }))}
              />
            </label>
          </fieldset>
          <fieldset className="admin-branch-ui-card">
            <legend className="mono small">OBSERVE path</legend>
            <label className="field">
              <span className="mono label-text">Kicker</span>
              <input
                className="terminal-input mono"
                value={uiDraft.branchObserveKicker}
                onChange={(e) => setUiDraft((u) => ({ ...u, branchObserveKicker: e.target.value }))}
              />
            </label>
            <label className="field">
              <span className="mono label-text">Title</span>
              <input
                className="terminal-input mono"
                value={uiDraft.branchObserveTitle}
                onChange={(e) => setUiDraft((u) => ({ ...u, branchObserveTitle: e.target.value }))}
              />
            </label>
            <label className="field">
              <span className="mono label-text">Description</span>
              <textarea
                className="terminal-input mono tall"
                rows={2}
                value={uiDraft.branchObserveDesc}
                onChange={(e) => setUiDraft((u) => ({ ...u, branchObserveDesc: e.target.value }))}
              />
            </label>
          </fieldset>
          <fieldset className="admin-branch-ui-card">
            <legend className="mono small">INFLUENCE path</legend>
            <label className="field">
              <span className="mono label-text">Kicker</span>
              <input
                className="terminal-input mono"
                value={uiDraft.branchInfluenceKicker}
                onChange={(e) => setUiDraft((u) => ({ ...u, branchInfluenceKicker: e.target.value }))}
              />
            </label>
            <label className="field">
              <span className="mono label-text">Title</span>
              <input
                className="terminal-input mono"
                value={uiDraft.branchInfluenceTitle}
                onChange={(e) => setUiDraft((u) => ({ ...u, branchInfluenceTitle: e.target.value }))}
              />
            </label>
            <label className="field">
              <span className="mono label-text">Description</span>
              <textarea
                className="terminal-input mono tall"
                rows={2}
                value={uiDraft.branchInfluenceDesc}
                onChange={(e) => setUiDraft((u) => ({ ...u, branchInfluenceDesc: e.target.value }))}
              />
            </label>
          </fieldset>
        </div>
      </details>

      <details className="admin-nested-details">
        <summary className="mono small admin-nested-summary">Completion screen</summary>
        <label className="field">
          <span className="mono label-text">Status line prefix</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.completeSlugPrefix}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.completeSlugPrefix}
            onChange={(e) => setUiDraft((u) => ({ ...u, completeSlugPrefix: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Completion title</span>
          <span className="field-hint muted small">Default: {DEFAULT_QUEST_UI.completeTitle}</span>
          <input
            className="terminal-input mono"
            value={uiDraft.completeTitle}
            onChange={(e) => setUiDraft((u) => ({ ...u, completeTitle: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Completion lede</span>
          <span className="field-hint muted small">Use {'{branch}'} for the path name.</span>
          <textarea
            className="terminal-input mono tall"
            rows={3}
            value={uiDraft.completeLede}
            onChange={(e) => setUiDraft((u) => ({ ...u, completeLede: e.target.value }))}
          />
        </label>
        <label className="field">
          <span className="mono label-text">Completion note</span>
          <textarea
            className="terminal-input mono tall"
            rows={2}
            value={uiDraft.completeNote}
            onChange={(e) => setUiDraft((u) => ({ ...u, completeNote: e.target.value }))}
          />
        </label>
      </details>
    </div>
  )
}
