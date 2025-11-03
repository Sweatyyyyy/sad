<script lang="ts">
    import { CONFIG, IS_BROWSER, INMENU } from './stores/stores';
    import { InitialiseListen } from '@utils/listeners';
    import { ReceiveEvent, SendEvent } from '@utils/eventsHandlers';
    let spawns: Array<{label: string}> = [
        {
            label: 'Lombank apartment Tower',
        },
        {
            label: 'LSIA',
        },
        {
            label: 'Bolingbroke Penitentiary',
        },
        {
            label: 'Mission Row PD',
        },
        {
            label: 'Sandy PD',
        },
        {
            label: 'Paleto PD',
        },
    ]

    CONFIG.set({
        fallbackResourceName: 'debug',
        allowEscapeKey: true,
    });
    InitialiseListen();
    function getRandomInt() {
        return Math.floor(Math.random() * 2) +1;
    }
    ReceiveEvent('setup', (data: {spawns: Array<{label: string}>, style: string}): void => {
        spawns = data.spawns;
        document.documentElement.style.setProperty('--primary', data.style);
    });
</script>

<main>
    <div class="title"><i class="fa-light fa-bus icon"></i> SELECT BUS STOP</div>
    <div class="stationtxt" style="left: 20vh;">Station</div>
    <div class="stationtxt" style="right: 20vh;">Time</div>
    <div class="list">
        {#each spawns as spawn, i}
            <button class="location" on:click={()=>SendEvent('spawnAt', spawn)}>
                <div class="locTxt" style="left: 0vh; padding-left:10vh">{spawn.label}</div>
                <div class="locTxt" style="right: 10vh; width: 20%;">{((i+1) *2) + getRandomInt()} min</div>
            </button>
        {/each}
    </div>
</main>

<style>
    .icon {
        position: relative;
        top: -0.2vh;
        font-size: 9vh;
    }
    .title {
        margin-top: 0vh;
        text-align: center;
        font-size: 12vh;
        color: var(--primary);
        text-shadow: 0 0 0.5vh var(--primary);
    }
    .stationtxt {
        position: absolute;
        font-size: 7vh;
        color: rgb(177, 177, 177);
    }
    .list {
        position: absolute;
        top: 29vh;
        width: 100%;
        height: 70.7vh;
        overflow: auto;
    }
    .location {
        width: 100%;
        font-size: 6.5vh;
        letter-spacing: 1.5vh;
        word-spacing: 4vh;
        display: flex;
        transition: scale 100ms;
    }
    .location:hover {
        color: #272a2e;
        background-color: var(--primary);
        box-shadow: 0 0 1vh var(--primary);
        scale: 1.05;
    }
    .locTxt {
        position: relative;
        width: 80%;
        text-align: left;
    }
    ::-webkit-scrollbar {
        width: 0vh;
    }
    main {
        position: absolute;
        left: 0;
        top: 0;
        z-index: 100;
        user-select: none;
        box-sizing: border-box;
        padding: 0;
        margin: 0;
        height: 100vh;
        width: 100vw;
        background-color: #272a2e;
        letter-spacing: 1.5vh;
        word-spacing: 4vh;
        font-family: 'DS-Digital', sans-serif;
    }
</style>

{#if import.meta.env.DEV}
    {#if $IS_BROWSER}
        {#await import('./providers/Debug.svelte') then { default: Debug }}
            <Debug />
        {/await}
    {/if}
{/if}
