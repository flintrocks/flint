const nj = require('nunjucks');
const env = new nj.Environment();
const fs = require('fs');
const path = require('path');
const mkdirp = require('mkdirp');

env.addFilter('camelCase', str => str.charAt(0).toLowerCase() + str.substr(1));

for (const source of [
  'AST/ASTPass/ASTPass'
]) {
  mkdirp.sync(`.derived-sources/${path.dirname(source)}`);
  fs.writeFileSync(
    `.derived-sources/${source}.swift`,
    env.renderString(
      fs.readFileSync(`Sources/${source}.template.swift`, 'utf8')
    )
  );
}