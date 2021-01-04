import * as core from "@actions/core";
import { performance } from "perf_hooks";
export async function measure<T>({
	name,
	block,
}: {
	name: string;
	block: () => Promise<T>;
}): Promise<void> {
	return await core.group(name, async () => {
		const start = performance.now();
		try {
			await block();
		} catch (error) {
			core.setFailed(error.message);
		} finally {
			const end = performance.now();
			const duration = (end - start) / 1000.0;
			core.info(`Took ${duration.toFixed(2).padStart(6)} seconds`);
		}
	});
}
export function isExactKeyMatch(key: string, cacheKey?: string): boolean {
	return !!(
		cacheKey &&
		cacheKey.localeCompare(key, undefined, {
			sensitivity: "accent",
		}) === 0
	);
}
export function getInputAsArray(
	name: string,
	options?: core.InputOptions
): string[] {
	return core
		.getInput(name, options)
		.split("\n")
		.map((s) => s.trim())
		.filter((x) => x !== "");
}
