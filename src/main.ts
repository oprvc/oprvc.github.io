import * as core from "@actions/core";
import * as exec from "@actions/exec";
import * as glob from "@actions/glob";
import * as cache from "@actions/cache";
import * as io from "@actions/io";
import * as crypto from "crypto";
import * as fs from "fs";
import * as prettier from "prettier/standalone";
import { Options } from "prettier";
import parserHTML from "prettier/parser-html";
import parserJS from "prettier/parser-babel";
import parserCSS from "prettier/parser-postcss";
import { measure, isExactKeyMatch, getInputAsArray } from "./common";

async function run(): Promise<void> {
	try {
		let jekyllSrc = "",
			gemSrc = "",
			gemArr: string[],
			jekyllArr: string[],
			hash: string,
			exactKeyMatch: boolean,
			installFailure = false,
			restoreKeys: string[],
			key: string;
		const INPUT_JEKYLL_SRC = core.getInput("jekyll_src", {}),
			SRC = core.getInput("src", {}),
			INPUT_GEM_SRC = core.getInput("gem_src", {}),
			INPUT_CUSTOM_OPTS = core.getInput("custom_opts", {}),
			INPUT_ENABLE_CACHE = core.getInput("enable_cache", {}),
			INPUT_KEY = core.getInput("key", {}),
			INPUT_RESTORE_KEYS = getInputAsArray("restore-keys"),
			INPUT_FORMAT_OUTPUT = core.getInput("format_output"),
			INPUT_PRETTIER_OPTS = core.getInput("prettier_opts"),
			INPUT_PRETTIER_IGNORE = getInputAsArray("prettier_ignore"),
			paths = ["vendor/bundle"];
		if (INPUT_RESTORE_KEYS.length > 0) restoreKeys = INPUT_RESTORE_KEYS;
		else restoreKeys = ["Linux-gems-", "bundle-use-ruby-Linux-gems-"];

		await measure({
			name: "resolve directories",
			block: async () => {
				// Resolve Jekyll directory
				if (INPUT_JEKYLL_SRC) {
					jekyllSrc = INPUT_JEKYLL_SRC;
					core.debug(
						`Using parameter value ${jekyllSrc} as a source directory`
					);
				} else if (SRC) {
					jekyllSrc = SRC;
					core.debug(
						`Using ${jekyllSrc} environment var value as a source directory`
					);
				} else {
					jekyllArr = await (
						await glob.create(
							["**/_config.yml", "!**/vendor/bundle/**"].join("\n")
						)
					).glob();
					for (let i = 0; i < jekyllArr.length; i++) {
						jekyllArr[i] = jekyllArr[i].replace(/_config\.yml/, "");
					}
					if (jekyllArr.length > 1) {
						throw new Error(
							`error: found ${jekyllArr.length} _config.yml! Please define which to use with input variable "JEKYLL_SRC"`
						);
					} else {
						jekyllSrc = jekyllArr[0];
					}
				}
				core.debug(`Resolved ${jekyllSrc} as source directory`);

				// Resolve Gemfile directory
				if (INPUT_GEM_SRC) {
					gemSrc = INPUT_GEM_SRC;
					if (!gemSrc.endsWith("Gemfile")) {
						if (!gemSrc.endsWith("/")) {
							gemSrc = gemSrc.concat("/");
						}
						gemSrc = gemSrc.concat("Gemfile");
					}
				} else {
					gemArr = await (
						await glob.create(["**/Gemfile", "!**/vendor/bundle/**"].join("\n"))
					).glob();
					if (gemArr.length > 1) {
						if (!jekyllSrc.endsWith("/")) {
							jekyllSrc = jekyllSrc.concat("/");
						}
						if (jekyllSrc.startsWith(".")) {
							jekyllSrc = jekyllSrc.replace(
								/\.\/|\./,
								`${process.env.GITHUB_WORKSPACE}/`
							);
						} else if (!jekyllSrc.startsWith("/")) {
							jekyllSrc = `${process.env.GITHUB_WORKSPACE}/`.concat(jekyllSrc);
						}
						for (const element of gemArr) {
							if (element.replace(/Gemfile/, "") === jekyllSrc) {
								gemSrc = element;
							}
						}
						if (!gemSrc) {
							throw new Error(
								`found ${gemArr.length} Gemfiles, and failed to resolve them! Please define which to use with input variable "GEM_SRC"`
							);
						} else {
							core.warning(`found ${gemArr.length} Gemfiles!`);
						}
					} else {
						gemSrc = gemArr[0];
					}
				}
				core.debug(`Resolved ${gemSrc} as Gemfile`);
				core.exportVariable("BUNDLE_GEMFILE", `${gemSrc}`);
			},
		});

		if (INPUT_ENABLE_CACHE) {
			await measure({
				name: "restore bundler cache",
				block: async () => {
					if (!INPUT_KEY) {
						hash = crypto
							.createHash("sha256")
							.update(fs.readFileSync(`${gemSrc}.lock`))
							.digest("hex");
						core.debug(`Hash of Gemfile.lock: ${hash}`);
						key = `Linux-gems-${hash}`;
					} else key = INPUT_KEY;
					try {
						const cacheKey = await cache.restoreCache(paths, key, restoreKeys);
						if (!cacheKey) {
							core.info(
								`Cache not found for input keys: ${[key, ...restoreKeys].join(
									", "
								)}`
							);
							return;
						}
						exactKeyMatch = isExactKeyMatch(key, cacheKey);
					} catch (error) {
						if (error.name === cache.ValidationError.name) {
							throw error;
						} else {
							core.warning(error.message);
						}
					}
					return;
				},
			});
		}

		await measure({
			name: "bundle install",
			block: async () => {
				await exec.exec("bundle config set deployment true");
				await exec.exec(
					`bundle config path ${process.env.GITHUB_WORKSPACE}/vendor/bundle`
				);
				try {
					await exec.exec(
						`bundle install --jobs=4 --retry=3 --gemfile=${gemSrc}`
					);
				} catch (error) {
					installFailure = true;
					core.error(
						'Gemfile.lock probably needs updating. Run "bundle install" locally and commit changes. Exiting action'
					);
					throw error;
				}
				return;
			},
		});

		if (!installFailure) {
			await measure({
				name: "jekyll build",
				block: async () => {
					core.exportVariable("JEKYLL_ENV", "production");
					return await exec.exec(
						`bundle exec jekyll build -s ${jekyllSrc} ${INPUT_CUSTOM_OPTS}`
					);
				},
			});

			// maybe run this async with saving cache
			if (INPUT_FORMAT_OUTPUT || INPUT_PRETTIER_OPTS) {
				await measure({
					name: "format output html files",
					block: async () => {
						const globFiles = ["_site/**/*.html"];
						if (INPUT_PRETTIER_IGNORE) {
							globFiles.push(
								...INPUT_PRETTIER_IGNORE.map((i) => "!_site/" + i)
							);
						}
						const formatFileArray = await (
							await glob.create(globFiles.join("\n"))
						).glob();
						let defaultOpts: Options = {
							parser: "html",
							plugins: [parserHTML, parserCSS, parserJS],
						};
						if (INPUT_PRETTIER_OPTS) {
							defaultOpts = {
								...defaultOpts,
								...JSON.parse(INPUT_PRETTIER_OPTS),
							};
						}

						const cacheHTMLPath = ["_site/**/*.cache"],
							formatCacheList = [],
							HTMLFiles: {
								[key: string]: string;
							} = {};
						let exactHTMLKeyMatch = false,
							filesConcat = "";
						for (const element of formatFileArray) {
							HTMLFiles[element] = fs.readFileSync(element, "utf8");
							filesConcat = filesConcat + HTMLFiles[element];
						}
						const cacheHTMLKey = `Linux-cacheFormatHTML-${crypto
							.createHash("sha256")
							.update(filesConcat)
							.digest("hex")}`;
						try {
							const cacheKey = await cache.restoreCache(
								cacheHTMLPath,
								cacheHTMLKey,
								["Linux-cacheFormatHTML-"]
							);
							if (!cacheKey) {
								core.info("No HTML cache");
							} else
								exactHTMLKeyMatch = isExactKeyMatch(cacheHTMLKey, cacheKey);
						} catch (error) {
							if (error.name === cache.ValidationError.name) {
								throw error;
							} else {
								core.warning(error.message);
							}
						}
						for (const element of formatFileArray) {
							core.debug(element);
							if (fs.existsSync(`${element}.cache`)) {
								const cachedFile = fs.readFileSync(`${element}.cache`, "utf8");
								if (HTMLFiles[element] === cachedFile) {
									await io.cp(`${element}.prettier.cache`, element);
									formatCacheList.push(element);
									continue;
								}
							}
							const formatted = prettier.format(
								HTMLFiles[element],
								defaultOpts
							);
							if (HTMLFiles[element].length > 10000) {
								formatCacheList.push(element);
								fs.writeFileSync(`${element}.cache`, HTMLFiles[element]);
								fs.writeFileSync(`${element}.prettier.cache`, formatted);
							}
							fs.writeFileSync(element, formatted);
						}
						if (formatCacheList.length >= 1) {
							if (!exactHTMLKeyMatch) {
								try {
									await cache.saveCache(cacheHTMLPath, cacheHTMLKey);
								} catch (error) {
									if (error.name === cache.ValidationError.name) {
										throw error;
									} else if (error.name === cache.ReserveCacheError.name) {
										core.info(error.message);
									} else {
										core.warning(error.message);
									}
								}
							}
							for (const element of formatCacheList) {
								await io.rmRF(`${element}.cache`);
								await io.rmRF(`${element}.prettier.cache`);
							}
						}
						return;
					},
				});
			}

			if (INPUT_ENABLE_CACHE) {
				await measure({
					name: "save bundler cache",
					block: async () => {
						if (exactKeyMatch) {
							core.info(
								`Cache hit occurred on the primary key ${key}, not saving cache.`
							);
							return;
						}
						try {
							await cache.saveCache(paths, key);
						} catch (error) {
							if (error.name === cache.ValidationError.name) {
								throw error;
							} else if (error.name === cache.ReserveCacheError.name) {
								core.info(error.message);
							} else {
								core.warning(error.message);
							}
						}
						return;
					},
				});
			}
		}
	} catch (error) {
		core.setFailed(error.message);
	}
}
run();
