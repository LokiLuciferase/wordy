# Wordy

**Wordy** is a word spelling puzzle.

You have **6 guesses** to find out the **secret 5-letter word**.

![1.png](png/1.png)

---


![green.png](png/green.png)

If a letter appears **green**, that means that this letter **exists in the secret word, and is in the right position**.

![yellow.png](png/yellow.png)

If a letter appears **yellow**, that means that this letter **exists in the secret word, but is in NOT the right position**.

![red.png](png/red.png)

If a letter appears **red**, that means that this letter **does NOT appear in the secret word AT ALL**.

![3.png](png/3.png)

As mentioned above, there are **6 guesses** to find the secret word.


![4.png](png/4.png)


![6.png](png/6.png)
---

### Dependencies

* As mentioned above, this script is using the word list contained in `/usr/share/dict/words`.

  If your distro doesn't include this installed, you can install the respective package (`wordlist`, `words`) using the respective command (`apt`, `pacman`).

### Install

```
git clone https://github.com/LokiLuciferase/wordy.git

cd wordy/

```

To run the script from any directory, it has to be made executable, and then copied to `$PATH`:

```

chmod +x wordy.sh

cp wordy.sh ~/.local/bin/

```

### Run

Just run:

```
wordy.sh
```
This code is forked from: [wordly](https://gitlab.com/christosangel/wordy)

This TUI game was inspired by [wordle](https://www.nytimes.com/games/wordle/index.html)

There is another project that might interest you:

[https://gitlab.com/christosangel/wordle-solver](https://gitlab.com/christosangel/wordle-solver)


***Have fun!***
